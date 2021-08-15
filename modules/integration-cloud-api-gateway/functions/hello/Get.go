package p

import (
	"encoding/json"
	"fmt"
	"net/http"
)

type GetResponse struct {
	Message string `json:"message"`
}

func Get(w http.ResponseWriter, r *http.Request) {
	fmt.Println("GET params were:", r.URL.Query())
	w.Header().Set("Content-Type", "application/json")

	q := r.URL.Query()
	nickname := q.Get("nickname")

	if nickname == "" {
		jsonBytes, _ := json.Marshal(GetResponse{Message: "NG"})
		w.WriteHeader(http.StatusInternalServerError)
		w.Write(jsonBytes)
		return
	}

	jsonBytes, _ := json.Marshal(GetResponse{Message: "OK"})
	w.WriteHeader(http.StatusOK)
	w.Write(jsonBytes)
}
