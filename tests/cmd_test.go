package test

import (
	"testing"

	"fmt"
	"github.com/royburns/goRemoteCMD/models"
)

// TestGet is a sample to run an endpoint test
// func TestGet(t *testing.T) {
// 	r, _ := http.NewRequest("GET", "/object", nil)
// 	w := httptest.NewRecorder()
// 	beego.BeeApp.Handlers.ServeHTTP(w, r)

// 	beego.Trace("testing", "TestGet", "Code[%d]\n%s", w.Code, w.Body.String())

// 	Convey("Subject: Test Station Endpoint\n", t, func() {
// 		Convey("Status Code Should Be 200", func() {
// 			So(w.Code, ShouldEqual, 200)
// 		})
// 		Convey("The Result Should Not Be Empty", func() {
// 			So(w.Body.Len(), ShouldBeGreaterThan, 0)
// 		})
// 	})
// }

func TestCmd(t *testing.T) {
	// var cmd models.Cmd
	// cmd.Name = "dir"
	// cmd.Params = ""

	res, err := models.Run("dir", "")
	fmt.Println(res.Info)
	fmt.Println(err)
}
