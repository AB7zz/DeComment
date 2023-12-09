import React from 'react'
import BotNav from '~components/BotNav'
import Navbar from '~components/Navbar'
import { useStateContext } from '~context/StateContext'
import Comments from '~pages/Comments'
import Connect from '~pages/Connect'
import Home from '~pages/Home'
import Profile from '~pages/Profile'
import TestIPFS from '~pages/TestIPFS'
import '~style.css'

const Main = () => {
    const {page, setPage} = useStateContext()
    const renderContent = () => {
        if(page == '/'){
            return (
                <Home />
            )
        }else if(page == '/comments'){
            return(
                <Comments />
            )
        }else if(page == '/profile'){
            return(
                <Profile />
            )
        }else if(page == '/testipfs'){
            return(
                <TestIPFS />
            )
        }else if(page == '/connect'){
            return(
                <Connect />
            )
        }
    }

    return(
        <div className="w-[370px]">
            <Navbar />
            {renderContent()}
            <BotNav />
        </div>
    )
}

export default Main