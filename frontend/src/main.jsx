import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.jsx';
import './index.css';
import { Provider } from 'react-redux';
import { PersistGate } from 'redux-persist/integration/react';
import { store, persistor } from './redux/store';
import AutoLogout from './components/AutoLogout.jsx';
import axios from 'axios';

axios.defaults.baseURL = import.meta.env.VITE_API_URL || 'http://52.45.15.38:5005';

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <Provider store={store}>
      <PersistGate loading={null} persistor={persistor}>
        <AutoLogout />
        <App />
      </PersistGate>
    </Provider>
  </React.StrictMode>
);
