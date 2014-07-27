package controllers

import (
	"encoding/json"
	"fmt"
	"github.com/astaxie/beego"
	// "github.com/royburns/goRemoteCMD/models"
)

type CMDController struct {
	beego.Controller
}

// command: this.lineBuffer,
// dir: this.env.dir,
// user: this.env.userid,
// pass: this.env.password
type cmd struct {
	command string
	dir     string
	user    string
	pass    string
}

func (this *CMDController) Post() {
	// var ob models.Object

	//
	fmt.Println(this.Ctx.Input.GetData("command"))
	fmt.Println(this.Ctx.Input.IsAjax())
	fmt.Println(this.Ctx.Input.IsPost())
	fmt.Println(this.Ctx.Input.Method())
	fmt.Println(this.Ctx.Input.Param("command"))
	fmt.Println(this.Ctx.Input.Query("command"))

	var ob cmd
	fmt.Println(string(this.Ctx.Input.RequestBody))
	json.Unmarshal(this.Ctx.Input.RequestBody, &ob)
	fmt.Println(ob)

	ob.command = this.Ctx.Input.Query("command")
	ob.dir = "C:\\"
	ob.user = "royburns"
	ob.pass = "123123"
	fmt.Println(ob)

	// objectid := models.AddOne(ob)
	// this.Data["json"] = map[string]string{"ObjectId": objectid}
	this.Data["json"] = ob
	this.ServeJson()
}

func (this *CMDController) Get() {
	// name := this.Ctx.Input.Params[":name"]
	// fmt.Println(name)
	// if name != "" {
	// 	// ob, err := models.GetOne(name)
	// 	// if err != nil {
	// 	// 	this.Data["json"] = err
	// 	// } else {
	// 	// 	this.Data["json"] = ob
	// 	// }
	// 	res, e := models.Run(name, "")
	// 	if e != nil {
	// 		fmt.Println("\n" + e.Error())
	// 	}
	// 	// value, _ := json.Marshal(res)
	// 	this.Data["json"] = res
	// } else {
	// 	// obs := models.GetAll()
	// 	// this.Data["json"] = obs
	// 	fmt.Println("The command is not exists.")
	// 	this.Data["json"] = "The command is not exists."
	// }
	// this.ServeJson()

	fmt.Println("Get")
	this.TplNames = "remote_cmd.tpl"
}

// func (this *CMDController) Put() {
// 	objectId := this.Ctx.Input.Params[":name"]
// 	var ob models.Object
// 	json.Unmarshal(this.Ctx.Input.RequestBody, &ob)

// 	err := models.Update(objectId, ob.Score)
// 	if err != nil {
// 		this.Data["json"] = err
// 	} else {
// 		this.Data["json"] = "update success!"
// 	}
// 	this.ServeJson()
// }

// func (this *CMDController) Delete() {
// 	objectId := this.Ctx.Input.Params[":name"]
// 	models.Delete(objectId)
// 	this.Data["json"] = "delete success!"
// 	this.ServeJson()
// }
