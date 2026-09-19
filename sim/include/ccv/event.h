//===-- event.h - CCV event stream emit API ---------------------*- C++ -*-===//
//
// §8 Stage 1c: the event schema MECHANISM -- format, versioning, emit API,
// Perfetto mapping. Not the event list; that populates at Stage 2 (load-bearing,
// interface-defined) and Stage 4a per block (arbitration-sensitive,
// internals-defined).
//
// WHY THIS IS ONE ARTIFACT AND NOT TWO
//
// §3: "Trace creation and RTL correlation have collapsed into one artifact.
// The per-instruction event stream from §1 IS the trace -- there is no separate
// trace format to design." So this API is simultaneously the debug/visualization
// feed and the §5 correlation feed, and it has to be good enough for both:
// cheap enough to leave on for a full kernel, and deterministic enough that two
// streams can be diffed byte for byte.
//
// WHY BINARY RECORDS AND NOT JSON
//
// §1 wants every event from first decode through retirement, per instruction,
// for real compiled kernels. That is tens of millions of records. A fixed
// 32-byte record keeps a full-kernel trace tractable, gives DPI-C a trivial C
// ABI to write through (below), and makes §5 correlation a memcmp rather than a
// parse. Chrome/Perfetto JSON is a VIEW, produced on demand by
// tools/trace2perfetto.py -- not the storage format.
//
// THE RTL EMIT PATH IS A STAGE 1C DECISION, NOT A 4C ONE
//
// §8 is explicit about this trap: "designing a C++-only emit API at Stage 1c
// and discovering at 4c that SystemVerilog can't feed it cleanly means a
// retrofit across every block already built." The decision is DPI-C into this
// same library -- see sim/dpi/. It is exercised at 1c by a trivial SystemVerilog
// module, as §8's exit criteria require, rather than assumed to work.
//
//===----------------------------------------------------------------------===//
#ifndef CCV_EVENT_H
#define CCV_EVENT_H

#include <cstdint>
#include <cstdio>
#include <string>

#include "ccv_event_ids.h"

namespace ccv {

/// One event, pinned to an instruction and a cycle (§1).
///
/// 32 bytes, fixed. Field order is chosen so the struct is naturally aligned
/// with no padding, which makes the on-disk layout identical to the in-memory
/// one and lets the writer emit whole records without serialization.
struct Event {
  uint64_t cycle;      ///< when
  uint64_t instr_uid;  ///< which instruction. §1: every event is pinned to one.
  uint16_t event_id;   ///< EventId, from the schema
  uint16_t unit;       ///< Unit, the track this belongs to
  uint32_t a;          ///< payload; the schema names these per event
  uint32_t b;
  uint32_t c;
};
static_assert(sizeof(Event) == 32, "Event must stay 32 bytes: the on-disk "
                                   "layout is the in-memory one");

/// File header. Written once, checked on read.
struct TraceHeader {
  char     magic[8];       ///< "CCVTRACE"
  uint32_t schema_version;
  uint32_t record_size;
  char     schema_hash[16];///< semantic hash; see tools/gen-event-schema.py
  uint64_t reserved;
};
static_assert(sizeof(TraceHeader) == 40, "TraceHeader layout is on-disk");

/// Buffered writer. Deliberately not thread-safe: §1's timing model is a
/// single-threaded event loop driving one clock, and a lock per event would
/// cost more than the events do.
class EventWriter {
public:
  EventWriter() = default;
  ~EventWriter();

  /// Returns false and leaves the writer disabled if the file cannot be opened,
  /// rather than throwing -- a trace is an observation, and failing to record
  /// one must never change what the model does.
  bool open(const std::string &path);
  void close();

  bool enabled() const { return f_ != nullptr; }

  void emit(uint64_t cycle, uint64_t instr_uid, EventId id, uint16_t unit,
            uint32_t a = 0, uint32_t b = 0, uint32_t c = 0);

  uint64_t count() const { return count_; }

private:
  std::FILE *f_ = nullptr;
  uint64_t count_ = 0;
};

/// The process-wide writer.
///
/// A singleton rather than a passed-around handle for one specific reason: the
/// DPI-C bridge is called from SystemVerilog, which has no way to carry a C++
/// object pointer around. §8's Stage 1c decision is that RTL instrumentation
/// feeds THIS library, so the library has to be reachable from a bare C
/// function with no context argument. Blocks in the timing model may still hold
/// their own writer if they ever need one.
EventWriter &traceWriter();

/// Reader, for tools/ and for the §5 correlation harness.
class EventReader {
public:
  bool open(const std::string &path);
  void close();
  ~EventReader();
  /// False on EOF. A truncated final record is reported as a short read rather
  /// than silently dropped, because a truncated trace and a complete one
  /// diverge in exactly the way a correlation bug does.
  bool next(Event &out);
  const TraceHeader &header() const { return hdr_; }
  bool schemaMatches() const;
  const std::string &error() const { return err_; }

private:
  std::FILE *f_ = nullptr;
  TraceHeader hdr_{};
  std::string err_;
};

} // namespace ccv
#endif // CCV_EVENT_H
