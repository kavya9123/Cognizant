

console.log("Welcome to the Community Portal");

document.addEventListener('DOMContentLoaded', () => {
    alert("Page is fully loaded!");
    renderEvents();
    const today = new Date();
    const [year, month, day] = [today.getFullYear(), String(today.getMonth() + 1).padStart(2, '0'), String(today.getDate()).padStart(2, '0')];
    dom.dateInput.min = `${year}-${month}-${day}`;
});
const dom = {
    dynamicEventsListContainer: document.getElementById('dynamicEventsList'),
    loadingSpinner: document.getElementById('loadingSpinner'),
    registrationStatusDiv: document.getElementById('registrationStatus'),
    eventRegistrationForm: document.getElementById('eventRegistrationForm'),
    nameInput: document.getElementById('name'),
    emailInput: document.getElementById('email'),
    phoneInput: document.getElementById('phone'),
    dateInput: document.getElementById('date'),
    eventTypeSelect: document.getElementById('eventType'),
    messageTextarea: document.getElementById('message'),
    charCountSpan: document.getElementById('charCount'),
    eventFeeDisplay: document.getElementById('eventFee'),
    preferredEventTypeSelect: document.getElementById('preferredEventType'),
    clearPreferencesButton: document.getElementById('clearPreferencesButton'),
    findNearbyEventsButton: document.getElementById('findNearbyEventsButton'),
    latitudeSpan: document.getElementById('latitude'),
    longitudeSpan: document.getElementById('longitude'),
    geoStatus: document.getElementById('geo-status'),
    promoVideo: document.getElementById('promoVideo'),
    videoStatus: document.getElementById('videoStatus'),
    feedbackMessageTextarea: document.getElementById('feedbackMessage'),
    feedbackCharCountSpan: document.getElementById('feedbackCharCount'),
    submitFeedbackButton: document.getElementById('submitFeedbackButton'),
};

let communityEvents = [
    { id: 'e1', name: 'Community Clean-Up Drive', date: '2025-06-15', seats: 100, category: 'community', description: 'Help keep our neighborhood clean!' },
    { id: 'e2', name: 'Summer Music Festival', date: '2025-07-20', seats: 500, category: 'music', description: 'Enjoy live music from local bands.' },
    { id: 'e3', name: 'Local Art Exhibition', date: '2025-08-01', seats: 50, category: 'art', description: 'Discover local talent and art.' },
    { id: 'e4', name: 'Web Development Workshop', date: '2025-09-05', seats: 30, category: 'workshop', description: 'Learn the basics of web development.' },
    { id: 'e5', name: 'Annual Charity Run', date: '2025-05-10', seats: 200, category: 'community', description: 'Run for a cause! (Past Event)' },
    { id: 'e6', name: 'Book Club Meeting', date: '2025-10-25', seats: 0, category: 'education', description: 'Discuss this month\'s book. (Full Event)' }
];

class Event {
    constructor(id, name, date, seats, category, description) {
        this.id = id;
        this.name = name;
        this.date = date;
        this.seats = seats;
        this.initialSeats = seats;
        this.category = category;
        this.description = description;
    }
    checkAvailability = () => this.seats > 0;
    decrementSeats = () => this.checkAvailability() ? (this.seats--, true) : false;
    incrementSeats = () => this.seats < this.initialSeats ? (this.seats++, true) : false;
}

communityEvents = communityEvents.map(eventData => new Event(eventData.id, eventData.name, eventData.date, eventData.seats, eventData.category, eventData.description));

const eventRegistrationTrackers = {};
communityEvents.forEach(event => {
    let count = 0;
    eventRegistrationTrackers[event.id] = () => {
        count++;
        console.log(`Event ${event.id} now has ${count} registrations.`);
        return count;
    };
});

async function registerUser(eventId) {
    const eventToRegister = communityEvents.find(event => event.id === eventId);
    if (!eventToRegister) return updateStatus('Error: Event not found.', 'error', true);

    try {
        if (eventToRegister.decrementSeats()) {
            const mockRegistrationData = { eventId, timestamp: new Date().toISOString(), attendeeCount: eventRegistrationTrackers[eventId]() };
            dom.loadingSpinner.style.display = 'block';
            dom.registrationStatusDiv.style.display = 'none';
            await new Promise(resolve => setTimeout(resolve, 1500));
            const mockApiResponse = { success: true, message: `Successfully registered for ${eventToRegister.name}!` };
            updateStatus(mockApiResponse.message, mockApiResponse.success ? 'success' : 'error', true);
            if (mockApiResponse.success) console.log(`Registration successful for ${eventToRegister.name}. Seats left: ${eventToRegister.seats}`);
            renderEvents();
        } else {
            updateStatus(`Registration failed: ${eventToRegister.name} is full or past.`, 'error', true);
        }
    } catch (error) {
        console.error("Registration error:", error);
        updateStatus(`An unexpected error occurred during registration: ${error.message}`, 'error', true);
    } finally {
        dom.loadingSpinner.style.display = 'none';
    }
}

function updateStatus(message, type, show) {
    dom.registrationStatusDiv.textContent = message;
    dom.registrationStatusDiv.className = `status-message ${type}`;
    dom.registrationStatusDiv.style.display = show ? 'block' : 'none';
}


function renderEvents(eventsToDisplay = communityEvents) {
    dom.dynamicEventsListContainer.innerHTML = '';
    dom.loadingSpinner.style.display = 'none';

    if (eventsToDisplay.length === 0) {
        dom.dynamicEventsListContainer.innerHTML = '<p style="text-align: center; color: #6b7280; grid-column: 1 / -1;">No upcoming events found.</p>';
        return;
    }

    eventsToDisplay.forEach(event => {
        const eventDate = new Date(event.date);
        const now = new Date();
        now.setHours(0, 0, 0, 0);
        const isPastEvent = eventDate < now;
        const isFullEvent = !event.checkAvailability();

        const eventCard = document.createElement('div');
        eventCard.classList.add('event-card');
        if (isPastEvent) eventCard.classList.add('past-event');
        if (isFullEvent) eventCard.classList.add('full-event');

        const { name, date, seats, category, description, id } = event;

        eventCard.innerHTML = `
            <h4>${name}</h4>
            <p><strong>Date:</strong> ${date}</p>
            <p><strong>Category:</strong> <span class="category">${category.charAt(0).toUpperCase() + category.slice(1)}</span></p>
            <p>${description}</p>
            <p><strong>Seats Available:</strong> ${seats} <span class="availability">(${isFullEvent ? 'Full' : (isPastEvent ? 'Past Event' : 'Available')})</span></p>
            <button class="register-button" data-event-id="${id}" ${isFullEvent || isPastEvent ? 'disabled' : ''}>Register</button>
        `;
        dom.dynamicEventsListContainer.appendChild(eventCard);
    });

    document.querySelectorAll('.register-button').forEach(button => {
        button.addEventListener('click', e => registerUser(e.target.dataset.eventId));
    });
}

dom.eventRegistrationForm.addEventListener('submit', async e => {
    e.preventDefault();
    document.querySelectorAll('.error-message').forEach(el => el.textContent = '');
    dom.registrationStatusDiv.style.display = 'none';

    let isValid = true;
    const validate = (input, errorId, msg, regex = null) => {
        const errorEl = document.getElementById(errorId);
        if (input.value.trim() === '') {
            errorEl.textContent = msg;
            isValid = false;
        } else if (regex && !regex.test(input.value)) {
            errorEl.textContent = `Please enter a valid ${input.id}.`;
            isValid = false;
        } else {
            errorEl.textContent = '';
        }
    };

    validate(dom.nameInput, 'nameError', 'Name is required.');
    validate(dom.emailInput, 'emailError', 'Email is required.', /^[^@]+@[^@]+\.[a-zA-Z]{2,}$/);
    validate(dom.dateInput, 'dateError', 'Event date is required.');
    validate(dom.eventTypeSelect, 'eventTypeError', 'Please select an event type.');
    if (dom.phoneInput.value.trim() !== '' && !/^\d{3}-\d{3}-\d{4}$/.test(dom.phoneInput.value)) {
        document.getElementById('phoneError').textContent = 'Phone number must be in XXX-XXX-XXXX format.';
        isValid = false;
    }

    if (isValid) {
        const formData = {
            name: dom.nameInput.value,
            email: dom.emailInput.value,
            phone: dom.phoneInput.value,
            date: dom.dateInput.value,
            eventType: dom.eventTypeSelect.value,
            message: dom.messageTextarea.value
        };

        console.log("Submitting form data:", formData);
        dom.loadingSpinner.style.display = 'block';
        await new Promise(resolve => setTimeout(resolve, 2000));
        const mockResponse = { success: true, message: 'Registration successful!', data: formData };

        updateStatus(mockResponse.message, mockResponse.success ? 'success' : 'error', true);
        if (mockResponse.success) {
            dom.eventRegistrationForm.reset();
            dom.charCountSpan.textContent = '500';
            dom.eventFeeDisplay.textContent = 'Event Fee: $0';
        }
    } else {
        updateStatus('Please correct the errors in the form.', 'error', true);
    }
    dom.loadingSpinner.style.display = 'none';
});

if (dom.preferredEventTypeSelect) {
    const savedPreference = localStorage.getItem('preferredEventType');
    if (savedPreference) dom.preferredEventTypeSelect.value = savedPreference;
    dom.preferredEventTypeSelect.addEventListener('change', e => {
        localStorage.setItem('preferredEventType', e.target.value);
        alert(`Your preferred event type has been saved as: ${e.target.value}`);
    });
}
if (dom.clearPreferencesButton) {
    dom.clearPreferencesButton.addEventListener('click', () => {
        localStorage.removeItem('preferredEventType');
        if (dom.preferredEventTypeSelect) dom.preferredEventTypeSelect.value = '';
        alert('Your preferred event type preference has been cleared.');
    });
}

// jQuery Integration
$(document).ready(() => {
    console.log("jQuery is ready!");
    $('nav a').on('click', function(event) {
        if (this.hash !== "") {
            event.preventDefault();
            $('html, body').animate({ scrollTop: $(this.hash).offset().top }, 800, () => window.location.hash = this.hash);
        }
    });
    $('#welcomeBanner').on('click', function() { $(this).fadeOut(500).fadeIn(500); });
    $('#eventRegistrationForm input, #eventRegistrationForm select, #eventRegistrationForm textarea').on('focus', function() {
        $(this).addClass('focused-input');
    }).on('blur', function() {
        $(this).removeClass('focused-input');
    });
});

// Character count for message textarea
if (dom.messageTextarea && dom.charCountSpan) {
    dom.messageTextarea.addEventListener('input', () => {
        const maxLength = dom.messageTextarea.getAttribute('maxlength');
        dom.charCountSpan.textContent = maxLength - dom.messageTextarea.value.length;
    });
}

// Character count for feedback message textarea
if (dom.feedbackMessageTextarea && dom.feedbackCharCountSpan) {
    dom.feedbackMessageTextarea.addEventListener('input', () => {
        const maxLength = dom.feedbackMessageTextarea.getAttribute('maxlength');
        dom.feedbackCharCountSpan.textContent = maxLength - dom.feedbackMessageTextarea.value.length;
    });
}

// Event fee display
if (dom.eventTypeSelect && dom.eventFeeDisplay) {
    dom.eventTypeSelect.addEventListener('change', () => {
        const fee = dom.eventTypeSelect.options[dom.eventTypeSelect.selectedIndex].dataset.fee || 0;
        dom.eventFeeDisplay.textContent = `Event Fee: $${fee}`;
    });
}

// Geolocation
if (dom.findNearbyEventsButton) {
    dom.findNearbyEventsButton.addEventListener('click', () => {
        dom.geoStatus.textContent = 'Attempting to find your location...';
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                position => {
                    dom.latitudeSpan.textContent = position.coords.latitude.toFixed(4);
                    dom.longitudeSpan.textContent = position.coords.longitude.toFixed(4);
                    dom.geoStatus.textContent = 'Location found!';
                },
                error => {
                    const errorMessages = {
                        [error.PERMISSION_DENIED]: "User denied the request for Geolocation.",
                        [error.POSITION_UNAVAILABLE]: "Location information is unavailable.",
                        [error.TIMEOUT]: "The request to get user location timed out.",
                        [error.UNKNOWN_ERROR]: "An unknown error occurred."
                    };
                    dom.geoStatus.textContent = `Error getting location: ${errorMessages[error.code] || 'Unknown error.'}`;
                    console.error("Geolocation Error:", error);
                    dom.latitudeSpan.textContent = 'N/A';
                    dom.longitudeSpan.textContent = 'N/A';
                },
                { enableHighAccuracy: true, timeout: 5000, maximumAge: 0 }
            );
        } else {
            dom.geoStatus.textContent = 'Geolocation is not supported by your browser.';
            dom.latitudeSpan.textContent = 'N/A';
            dom.longitudeSpan.textContent = 'N/A';
        }
    });
}

// Video status updates
if (dom.promoVideo && dom.videoStatus) {
    dom.promoVideo.addEventListener('play', () => {
        dom.videoStatus.textContent = 'Video is playing... Enjoy!';
        Object.assign(dom.videoStatus.style, { backgroundColor: '#d4edda', borderColor: '#28a745', color: '#155724' });
    });
    dom.promoVideo.addEventListener('pause', () => {
        dom.videoStatus.textContent = 'Video paused.';
        Object.assign(dom.videoStatus.style, { backgroundColor: '#fff3cd', borderColor: '#ffc107', color: '#856404' });
    });
    dom.promoVideo.addEventListener('ended', () => {
        dom.videoStatus.textContent = 'Video finished. Thank you for watching!';
        Object.assign(dom.videoStatus.style, { backgroundColor: '#cfe2ff', borderColor: '#007bff', color: '#004085' });
    });
    dom.promoVideo.addEventListener('error', () => {
        dom.videoStatus.textContent = 'Error loading video. Please try again later.';
        Object.assign(dom.videoStatus.style, { backgroundColor: '#f8d7da', borderColor: '#dc3545', color: '#721c24' });
    });
}

// Event Bubbling (Example)
if (dom.dynamicEventsListContainer) {
    dom.dynamicEventsListContainer.addEventListener('click', event => {
        if (event.target.classList.contains('register-button')) {
            console.log(`Event bubbling: Register button for event ID ${event.target.dataset.eventId} clicked.`);
        }
    });
}

// Feedback submission
if (dom.submitFeedbackButton) {
    dom.submitFeedbackButton.addEventListener('click', async () => {
        const feedbackMessage = dom.feedbackMessageTextarea.value.trim();
        if (feedbackMessage === '') {
            alert('Feedback message cannot be empty!');
            return;
        }
        console.log("Submitting feedback:", feedbackMessage);
        await new Promise(resolve => setTimeout(resolve, 1000));
        alert('Thank you for your feedback!');
        dom.feedbackMessageTextarea.value = '';
        dom.feedbackCharCountSpan.textContent = '500';
    });
}
