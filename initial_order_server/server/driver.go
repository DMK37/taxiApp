package server

type DriverInfo struct {
	DriverId string `json:"driverId"`
	Latitude float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
	Timestamp string `json:"timestamp"`
}

type SendToMessage struct {
	Ids []string `json:"ids"`
}