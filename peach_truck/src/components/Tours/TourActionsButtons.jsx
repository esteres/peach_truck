import React from 'react';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';
import {  FaInfoCircle } from 'react-icons/fa';

const TourActionsButtons = props => {
  const { tour } = props;

  return (
    <React.Fragment>
      <Link className="btn m-1 btn-primary" to={`/tours/${tour.id}`}>
        <FaInfoCircle />
      </Link>
    </React.Fragment>
  );
};

TourActionsButtons.propTypes = {
  tour: PropTypes.object.isRequired
};

export default TourActionsButtons;
