//===-- event.cpp - CCV event stream emit API -------------------*- C++ -*-===//
#include "ccv/event.h"

#include <cstring>

namespace ccv {

EventWriter::~EventWriter() { close(); }

bool EventWriter::open(const std::string &path) {
  close();
  f_ = std::fopen(path.c_str(), "wb");
  if (!f_)
    return false;

  TraceHeader h{};
  std::memcpy(h.magic, "CCVTRACE", 8);
  h.schema_version = kSchemaVersion;
  h.record_size = sizeof(Event);
  // Not null-terminated: the field is exactly the hash width, and the reader
  // compares it as a fixed-length block.
  std::memcpy(h.schema_hash, kSchemaHash, sizeof(h.schema_hash));
  h.reserved = 0;
  if (std::fwrite(&h, sizeof(h), 1, f_) != 1) {
    std::fclose(f_);
    f_ = nullptr;
    return false;
  }
  count_ = 0;
  return true;
}

void EventWriter::close() {
  if (f_) {
    std::fclose(f_);
    f_ = nullptr;
  }
}

void EventWriter::emit(uint64_t cycle, uint64_t instr_uid, EventId id,
                       uint16_t unit, uint32_t a, uint32_t b, uint32_t c) {
  if (!f_)
    return;
  Event e{cycle, instr_uid, static_cast<uint16_t>(id), unit, a, b, c};
  std::fwrite(&e, sizeof(e), 1, f_);
  ++count_;
}

EventWriter &traceWriter() {
  static EventWriter w;
  return w;
}

EventReader::~EventReader() { close(); }

bool EventReader::open(const std::string &path) {
  close();
  f_ = std::fopen(path.c_str(), "rb");
  if (!f_) {
    err_ = "cannot open " + path;
    return false;
  }
  if (std::fread(&hdr_, sizeof(hdr_), 1, f_) != 1) {
    err_ = "short header";
    close();
    return false;
  }
  if (std::memcmp(hdr_.magic, "CCVTRACE", 8) != 0) {
    err_ = "not a CCV trace";
    close();
    return false;
  }
  if (hdr_.record_size != sizeof(Event)) {
    err_ = "record size mismatch";
    close();
    return false;
  }
  return true;
}

bool EventReader::schemaMatches() const {
  return hdr_.schema_version == kSchemaVersion &&
         std::memcmp(hdr_.schema_hash, kSchemaHash, sizeof(hdr_.schema_hash)) == 0;
}

bool EventReader::next(Event &out) {
  if (!f_)
    return false;
  size_t n = std::fread(&out, sizeof(out), 1, f_);
  if (n == 1)
    return true;
  // Distinguish clean EOF from a truncated tail. A truncated trace diverges
  // from a complete one in exactly the way a correlation bug does, so it must
  // never be reported as simply "the end".
  //
  // The offset is measured from the start of the RECORD region, not from the
  // start of the file: the header is 40 bytes and records are 32, so a
  // file-relative modulus calls every clean EOF a truncation.
  long pos = std::ftell(f_);
  if (!std::feof(f_) ||
      (pos >= 0 &&
       (pos - static_cast<long>(sizeof(TraceHeader))) %
           static_cast<long>(sizeof(Event)) != 0))
    err_ = "truncated final record";
  return false;
}

void EventReader::close() {
  if (f_) {
    std::fclose(f_);
    f_ = nullptr;
  }
}

} // namespace ccv
