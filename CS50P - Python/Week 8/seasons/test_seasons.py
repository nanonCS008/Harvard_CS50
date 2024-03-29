import pytest
from seasons import calculateMinuteAsWords

def test_calculateMinuteAsWords():
    assert calculateMinuteAsWords("1999-01-01") == "Thirteen million, two hundred seventy-three thousand, nine hundred twenty minutes"
    assert calculateMinuteAsWords("1970-01-01") == "Twenty-eight million, five hundred twenty-six thousand, four hundred minutes"
    assert calculateMinuteAsWords("2000-11-15") == "Twelve million, two hundred eighty-eight thousand, nine hundred sixty minutes"
    with pytest.raises(SystemExit, match="Invalid date"):
        calculateMinuteAsWords("January 1, 1999")
