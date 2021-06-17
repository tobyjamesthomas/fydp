import React, { useState} from 'react';
import Popup from './Popup';
import './App.css';

function App() {
  const [isOpen, setIsOpen] = useState(false);

  const togglePopup = () => {
    setIsOpen(!isOpen);
  }

  return <div>
    <input class="button-up"
      type="button"
      value="Look Up"
      onClick={togglePopup}
    />
    <input class="button-right"
      type="button"
      value="Look Right"
      onClick={togglePopup}
    />
    <input class="button-left"
      type="button"
      value="Look Left"
      onClick={togglePopup}
    />
    <input class="button-down"
      type="button"
      value="Look Down"
      onClick={togglePopup}
    />
    {isOpen && <Popup
      content={<>
        <h1>Confirmation</h1>
        <b>Are you sure you want to complete this action?</b>
        <b></b>
        <button class="button-confirmation">Yes</button>
      </>}
      handleClose={togglePopup}
    />}
  </div>
}

export default App;