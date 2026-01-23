# Services Package

# Lazy imports to avoid circular dependencies
def get_mock_service():
    from app.services.mock_service import mock_flight_service
    return mock_flight_service

def get_gemini_service():
    from app.services.gemini_service import gemini_service
    return gemini_service

def get_amadeus_service():
    from app.services.amadeus_service import amadeus_service
    return amadeus_service

