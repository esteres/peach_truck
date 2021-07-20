import React, { createContext, useMemo, useContext, useReducer } from 'react';
import { tourReducer } from '../reducers/TourReducer';

const initialState = { tours: [] };

const TourStateContext = createContext(initialState);
const TourDispatchContext = createContext(() => {});

export const useTourState = () => {
  const context = useContext(TourStateContext);
  if (context === undefined) {
    throw new Error('useTourState must be used within an TourProvider');
  }
  return context;
};

export const useTourDispatch = () => {
  const context = useContext(TourDispatchContext);
  if (context === undefined) {
    throw new Error('useTourDispatch must be used within an TourProvider');
  }
  return context;
};

const TourProvider = ({ children }) => {
  const [state, dispatch] = useReducer(tourReducer, {});
  const [stateValue, dispatchValue] = useMemo(() => [state, dispatch], [state]);

  return (
    <TourStateContext.Provider value={stateValue}>
      <TourDispatchContext.Provider value={dispatchValue}> {children} </TourDispatchContext.Provider>
    </TourStateContext.Provider>
  );
};

export default TourProvider;
