import React from 'react';
import { Link } from 'react-router-dom';
import { FaCaretUp, FaCaretDown } from 'react-icons/fa';
import BootstrapTable from 'react-bootstrap-table-next';
import paginationFactory from 'react-bootstrap-table2-paginator';
import ToolkitProvider, { Search } from 'react-bootstrap-table2-toolkit';
import 'react-bootstrap-table-next/dist/react-bootstrap-table2.min.css';
import 'react-bootstrap-table2-paginator/dist/react-bootstrap-table2-paginator.min.css';

// TODO: Inject the actions column component from the parent and avoid the dependency
import TourActionsButtons from '../Tours/TourActionsButtons';
//import UserActionsButtons from '../users/userActionsButtons';

const Table = props => {
  const { SearchBar } = Search;
  const { name } = props;

  const buildCarets = order => {
    if (!order)
      return (
        <span>
          <FaCaretUp />
          <FaCaretDown />
        </span>
      );
    else if (order === 'asc')
      return (
        <span>
          <FaCaretUp />
        </span>
      );
    else if (order === 'desc')
      return (
        <span>
          <FaCaretDown />
        </span>
      );
    return <React.Fragment />;
  };

  const defaultColumnProps = {
    align: 'left'
  };

  const defaultColumnSortingProps = {
    ...defaultColumnProps,
    sort: true,
    sortCaret: order => {
      return buildCarets(order);
    }
  };

  const columns = props.columns.map(col => {
    if (col.dataField === 'actions') {
      return { ...col, ...defaultColumnProps };
    }
    return { ...col, ...defaultColumnSortingProps };
  });

  const buildActions = obj => {
    switch (name) {
      case 'Tour':
        return <TourActionsButtons tour={obj} />;
      default:
        return <React.Fragment />;
    }
  };

  const sizePerPageRenderer = ({ options, currSizePerPage, onSizePerPageChange }) => (
    <div className="btn-group" role="group">
      {options.map(option => {
        const isSelect = currSizePerPage === `${option.page}`;
        return (
          <button
            key={option.text}
            type="button"
            onClick={onSizePerPageChange(option.page)}
            className={`btn ${isSelect ? 'btn-primary' : 'page-link'}`}
          >
            {option.text}
          </button>
        );
      })}
    </div>
  );

  const buildData = list => {
    const paginationOptions = {
      sizePerPageRenderer,
      hidePageListOnlyOnePage: true,
      showTotal: true,
      hideSizePerPage: list.length <= 50,
      sizePerPageList: [
        { text: '50', value: 50 },
        { text: '100', value: 100 },
        {
          text: 'All',
          value: list.length
        }
      ]
    };

    const data = list.map(obj => {
      return { ...obj, actions: buildActions(obj) };
    });

    return (
      <ToolkitProvider search keyField={props.keyField} data={data} columns={columns}>
        {props => (
          <React.Fragment>
            <SearchBar {...props.searchProps} />
            <BootstrapTable hover pagination={paginationFactory(paginationOptions)} {...props.baseProps} />
          </React.Fragment>
        )}
      </ToolkitProvider>
    );
  };

  return buildData(props.list);
};

export default Table;