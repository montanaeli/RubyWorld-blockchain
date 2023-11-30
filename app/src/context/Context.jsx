import { createContext, useContext as useReactContext, useState } from "react";
import { ErrorToast } from "../components";

const Context = createContext();

// eslint-disable-next-line react/prop-types
export const ContextProvider = ({ children }) => {
    const [error, setError] = useState('');

    const closeErrorToast = () => {
        setError('');
    }

    const [wallet, setWallet] = useState('')

    const [contracts, setContracts] = useState()
    const [data, setData] = useState()

    return (
        <Context.Provider value={{ closeErrorToast, error, setError, data, setData, contracts, setContracts, wallet, setWallet }}>
            {children}
            {error ? <ErrorToast /> : null}
        </Context.Provider>
    );
};

// eslint-disable-next-line react-refresh/only-export-components
export const useContext = () => {
    return useReactContext(Context);
};

