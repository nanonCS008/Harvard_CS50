from numb3rs import validate


def test_valid():
    assert validate("192.168.0.1") == True
    assert validate("10.0.0.1") == True
    assert validate("172.16.0.1") == True
    assert validate("140.247.235.144") == True
    assert validate("255.255.255.255") == True


def test_invalid():
    assert validate("cat") == False
    assert validate("1.2.3.1000") == False
    assert validate("275.3.6.28") == False
    assert validate("192.168.0") == False
    assert validate("192.168.0.256") == False
    assert validate("192.168.0.") == False
    assert validate("192.168.0.-1") == False
    assert validate("2001:0db8:85a3:0000:0000:8a2e:0370:7334") == False
