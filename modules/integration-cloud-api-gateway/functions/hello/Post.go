package p

import (
	"encoding/json"
	"fmt"
	"net/http"
)

type PostResponse struct {
	Message string `json:"message"`
}

type RequestBody struct {
	Nickname string `json:"nickname"`
}

func Post(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Post data: ", r.Body)
	w.Header().Set("Content-Type", "application/json")

	reqb := RequestBody{}
	if err := json.NewDecoder(r.Body).Decode(&reqb); err != nil {
		jsonBytes, _ := json.Marshal(GetResponse{Message: "NG"})
		w.WriteHeader(http.StatusInternalServerError)
		w.Write(jsonBytes)
		return
	}
	fmt.Println(reqb)

	resp := PostResponse{Message: "OK"}
	jsonBytes, _ := json.Marshal(resp)
	w.WriteHeader(http.StatusOK)
	w.Write(jsonBytes)
}
