typedef struct packed {
  logic        valid;
  logic [31:0] payload;
  logic [5:0]  tag;
} issue_t;
