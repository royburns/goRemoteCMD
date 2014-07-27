package routers

import (
	"github.com/astaxie/beego"
	"github.com/royburns/goRemoteCMD/controllers"
)

func init() {
	beego.RESTRouter("/object", &controllers.ObjectController{})
	beego.Router("/cmd", &controllers.CMDController{})
	beego.Router("/cmd/:name", &controllers.CMDController{})
}
