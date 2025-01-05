package server

type RideMessage struct {
	RideId uint64 `json:"rideId"`
	Cost   string `json:"cost"`
	Client string `json:"client"`
	Source string `json:"source"`
	Destination string `json:"destination"`
	SourceLocation string `json:"sourceLocation"`
	DestinationLocation string `json:"destinationLocation"`
}
