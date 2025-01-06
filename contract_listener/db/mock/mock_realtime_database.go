package mock

type MockRealtimeDatabase struct {
}

func NewMockRealtimeDatabase() *MockRealtimeDatabase {
	return &MockRealtimeDatabase{}
}

func (m *MockRealtimeDatabase) PushRideCreatedNotification(id string, rideId uint64) error {
	return nil
}