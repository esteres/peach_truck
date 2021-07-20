import React from 'react';
import { BrowserRouter, Switch, Route , Redirect} from 'react-router-dom';
import Header from '../components/Shared/Header';
import TourProvider from '../store/TourProvider';
import ToursList from '../components/Tours/ToursList';
import TourDetails from '../components/Tours/TourDetails';

const AppRouter = () => {
    return (
    <BrowserRouter>
        <Header />
        <div className="main-content">
            <TourProvider>
                <Switch>
                    <Route
                        render={(props) => (
                            <ToursList {...props} />
                        )}
                        path={["/", "/tours"]}
                        exact={true}
                    />
                    <Route
                        render={(props) => (
                            <TourDetails {...props} />
                        )}
                        path="/tours/:id"
                    />
                    <Route component={() => <Redirect to="/" />} />
                </Switch>
            </TourProvider>
        </div>
    </BrowserRouter>
    );
};

export default AppRouter;