// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./Types.sol";

uint8 constant SHORT_FORMAT_HEX_LENGTH = 3;
uint8 constant LONG_FORMAT_HEX_LENGTH = 6;
uint8 constant PREFIXED_LONG_FORMAT_HEX_LENGTH = LONG_FORMAT_HEX_LENGTH + 1;
uint8 constant PREFIXED_SHORT_FORMAT_HEX_LENGTH = SHORT_FORMAT_HEX_LENGTH + 1;
bytes1 constant HEX_CODE_SYMBOL = 0x23;

error INVALID_HEX_STRING();
error INVALID_HEX_CHARACTER(bytes1 _character);

function newColorFromRGB(uint8 _red, uint8 _green, uint8 _blue) pure returns (Color) {
    return Color.wrap(
        bytes3(uint24(_blue)) | (bytes3(uint24(_green)) << 8) | bytes3(uint24(_red)) << 16
    );
}

function newColorFromRGB(bytes3 _rgb) pure returns (Color) {
    return Color.wrap(_rgb);
}

function newColorFromRGBString(string memory _string) pure returns (Color) {
    bytes memory _b = bytes(_string);
    uint256 _length = _b.length;
    uint256 _offset;

    // Check if the hex code is prefixed with '#', we make a new string with the prefix removed and we try again
    // ex. #FFFFFF or #FFF
    if((
        _length == PREFIXED_LONG_FORMAT_HEX_LENGTH ||
        _length == PREFIXED_SHORT_FORMAT_HEX_LENGTH
        ) && 
        _b[0] == HEX_CODE_SYMBOL
    ){ 
        unchecked {
             --_length;
            _offset = 1;
        }
    }

    // Check if the string is a long format hex string
    // ex. FFFFFF
    if(_length == LONG_FORMAT_HEX_LENGTH){
        bytes3 _color;
        unchecked {
            uint256 _pos = 5 + _offset;

            // Unrolled loop to save gas
            _color |= bytes3(
                uint24(
                    getHexFromASCII(uint8(_b[_pos]))
                )
            );
            _color |= bytes3(
                uint24(
                    getHexFromASCII(uint8(_b[--_pos])) << 4
                )
            );
            _color |= bytes3(
                uint24(
                    getHexFromASCII(uint8(_b[--_pos])) << 8
                )
            );
            _color |= bytes3(
                uint24(
                    getHexFromASCII(uint8(_b[--_pos])) << 12
                )
            );
            _color |= bytes3(
                uint24(
                    getHexFromASCII(uint8(_b[--_pos])) << 16
                )
            );
            _color |= bytes3(
                uint24(
                    getHexFromASCII(uint8(_b[--_pos])) << 20
                )
            );
        }

        return Color.wrap(_color);

    // Check if the string is a long format hex string
    // ex. FFF
    }else if(_length == SHORT_FORMAT_HEX_LENGTH){
        bytes3 _color;

        unchecked {
            uint256 _pos = 2 + _offset;
            uint256 _char;
            // Unrolled loop to save gas
            _char = getHexFromASCII(uint8(_b[_pos]));
            _color |= bytes3(
                uint24(
                    _char
                ) | uint24(
                    _char << 4
                )
            );

            _char = getHexFromASCII(uint8(_b[--_pos]));
            _color |= bytes3(
                uint24(
                    _char << 8
                ) | uint24(
                    _char << 12
                )
            );

            _char = getHexFromASCII(uint8(_b[--_pos]));
            _color |= bytes3(
                uint24(
                    _char << 16
                ) | uint24(
                    _char << 20
                )
            );
        }

        return Color.wrap(_color);
    
    }else {
        revert INVALID_HEX_STRING();
    }
}

function getHexFromASCII(uint8 _index) pure returns(uint256){
    unchecked {
        if (_index >= 48 && _index <= 57) {
            _index -= 48;
        } else if (_index >= 65 && _index <= 70) {
            _index -= 55;
        } else {
            revert INVALID_HEX_CHARACTER(bytes1(_index));
        }
    }

    return _index;
}
