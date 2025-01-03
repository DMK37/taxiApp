package server

type RideMessage struct {
	RideId string `json:"rideId"`
	Cost   string `json:"cost"`
	Client string `json:"client"`
}
