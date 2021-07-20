import React, { useEffect } from 'react';
import { toast } from 'react-toastify';
import { FaTruck} from 'react-icons/fa';
import ToursDataService from "../../services/ToursService";
import { useTourState, useTourDispatch } from '../../store/TourProvider';
import Table from "../Shared/Table";

const ToursList = () => {
  const { tours } = useTourState();
  const tourDispatch = useTourDispatch();

  const buildData = () => {

    if (tours && tours.length > 0) {
      const columns = [
        {
          text: 'Name',
          dataField: 'name'
        },
        {
          text: 'Season',
          dataField: 'season'
        },
        {
          text: 'Start date',
          dataField: 'start_date'
        },
        { text: 'Actions', dataField: 'actions' }
      ];

      return (
        <Table
          name="Tour"
          keyField="id"
          list={tours}
          columns={columns}
        />
      );
    } else {
      return (
        <React.Fragment>
          <div className="mb-2">There are not tours yet!</div>
        </React.Fragment>
      );
    }
  };

  useEffect(() => {
    ToursDataService.getAll(tourDispatch)
      .then(() => {

      })
      .catch(error => {
        toast.error(error);
      });
  }, [tourDispatch]);

  return (
    <React.Fragment>
      <div className="card">
        <div className="card-header d-inline-flex">
          <FaTruck className="main-color" size="30" />
          <h4 className="pl-2">Tours</h4>
        </div>
        <div className="card-body">{buildData()}</div>
      </div>
    </React.Fragment>
  );
};

export default ToursList;