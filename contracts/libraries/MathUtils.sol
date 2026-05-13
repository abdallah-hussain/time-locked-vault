// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

library MathUtils {
        function max(uint256 a, uint256 b) 
        internal
        pure
        returns (uint256)
           {
                return a > b ? a:b;
           }
}