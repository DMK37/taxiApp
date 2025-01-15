package mock

type MockRealtimeDatabase struct {
}

func NewMockRealtimeDatabase() *MockRealtimeDatabase {
	return &MockRealtimeDatabase{}
}

func (m *MockRealtimeDatabase) PushRideCreatedNotification(id string, rideId uint64) error {
	return nil
}

func (m *MockRealtimeDatabase) PushRideConfirmedNotification(id string, rideId uint64, driverId string) error {
	return nil
}

func (m *MockRealtimeDatabase) PushRideStartedNotification(id string, rideId uint64) error {
	return nil
}

func (m *MockRealtimeDatabase) PushRideCompletedNotification(id string, rideId uint64) error {
	return nil
}