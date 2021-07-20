import http from "../http-common";

const getAll = dispatch => {
    return http.get("/tours").then(response => {
        const tours = response.data.data.map(tour => {
            return { ...tour.attributes }
        });
        dispatch({
        type: 'SET_TOURS',
        payload: tours
        });
    });
}

// eslint-disable-next-line
const get = id => {
    return http.get(`/tours/${id}`);
};

const response = {
    getAll,
    get
};

export default response;