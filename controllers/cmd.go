package controllers

import (
	"encoding/json"
	"fmt"
	"github.com/astaxie/beego"
	"github.com/royburns/goRemoteCMD/models"
)

type CMDController struct {
	beego.Controller
}

func (this *CMDController) Post() {
	var ob models.Object
	json.Unmarshal(this.Ctx.Input.RequestBody, &ob)
	objectid := models.AddOne(ob)
	this.Data["json"] = map[string]string{"ObjectId": objectid}
	this.ServeJson()
}

func (this *CMDController) Get() {
	name := this.Ctx.Input.Params[":name"]
	fmt.Println(name)
	if name != "" {
		// ob, err := models.GetOne(name)
		// if err != nil {
		// 	this.Data["json"] = err
		// } else {
		// 	this.Data["json"] = ob
		// }
		res, _ := models.Run(name, "")
		// value, _ := json.Marshal(res)
		this.Data["json"] = res
	} else {
		// obs := models.GetAll()
		// this.Data["json"] = obs
		fmt.Println("The command is not exists.")
		this.Data["json"] = "The command is not exists."
	}
	this.ServeJson()
}

func (this *CMDController) Put() {
	objectId := this.Ctx.Input.Params[":name"]
	var ob models.Object
	json.Unmarshal(this.Ctx.Input.RequestBody, &ob)

	err := models.Update(objectId, ob.Score)
	if err != nil {
		this.Data["json"] = err
	} else {
		this.Data["json"] = "update success!"
	}
	this.ServeJson()
}

func (this *CMDController) Delete() {
	objectId := this.Ctx.Input.Params[":name"]
	models.Delete(objectId)
	this.Data["json"] = "delete success!"
	this.ServeJson()
}
