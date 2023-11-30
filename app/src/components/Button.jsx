/* eslint-disable react/prop-types */

export const Button = ({ children, onClick, isDisabled, type }) => {
    return <button className={`${isDisabled ? 'bg-blue-200' : 'bg-blue-600'} w-50 rounded-xl py-2 px-4 text-white h-fit`} onClick={onClick} type={type} disabled={isDisabled}>{children}</button>;
}

