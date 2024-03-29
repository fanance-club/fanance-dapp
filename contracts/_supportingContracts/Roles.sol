pragma solidity =0.5.16;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping(address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0), "Pauser address cannot be 0x00");
        require(!has(role, account), "Cannot add existing account as pauser");

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0), "Pauser address cannot be 0x00");
        require(
            has(role, account),
            "Cannot remove non existent account as pauser"
        );

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account)
        internal
        view
        returns (bool)
    {
        require(account != address(0), "Pauser address cannot be 0x00");
        return role.bearer[account];
    }
}
