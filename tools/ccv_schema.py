"""Shared schema lookups for the generators and checkers.

One place resolves a payload field's width, because six tools do it and a
rule implemented six times drifts. A channel may override the global
`field_widths` map with its own `field_widths` object: that is how one field
name (`req_id`) carries a different width on each hop, each sized by that
hop's outstanding window.
"""


def field_width(d, c, f):
    """Width expression for field `f` of channel `c`, or None if undecided."""
    own = c.get("field_widths", {})
    if f in own:
        return own[f]
    return d.get("field_widths", {}).get(f)
