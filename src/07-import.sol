// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {SillyStringUtils as StrUtil} from './07-import-source.sol';

contract ImportExercise {
    StrUtil.Haiku public haiku;

    function saveHaiku(string memory _line1, string memory _line2, string memory _line3) external {
        haiku = StrUtil.Haiku(_line1, _line2, _line3);
    }

    function getHaiku() external view returns (StrUtil.Haiku memory) {
        return haiku;
    }

    function shruggieHaiku() external view returns (StrUtil.Haiku memory) {
        return StrUtil.Haiku(haiku.line1, haiku.line2, StrUtil.shruggie(haiku.line3));
    }
}
