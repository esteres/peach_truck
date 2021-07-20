export const tourReducer = (state, action) => {
  switch (action.type) {
    case 'SET_TOURS':
      return {
        ...state,
        tours: [...action.payload]
      };
    default:
      return state;
  }
};
