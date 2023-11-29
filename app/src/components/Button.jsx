import PropTypes from 'prop-types';

export const Button = ({ children, onClick, isDisabled }) => {
    return <button className={`${isDisabled ? 'bg-blue-200' : 'bg-blue-600'} rounded-xl py-2 px-4 text-white`} onClick={onClick} disabled={isDisabled}>{children}</button>;
}

Button.propTypes = {
    children: PropTypes.node.isRequired,
    onClick: PropTypes.func.isRequired,
    isDisabled: PropTypes.bool,
};