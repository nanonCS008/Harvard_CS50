from um import count

def test_count():
    assert count("Um?") == 1
    assert count("Um, welcome, um, my, um, town") == 3
    assert count("um") == 1
    assert count("Hey, um, how are you?, um") == 2
    assert count("Um, thanks for the album") == 1
