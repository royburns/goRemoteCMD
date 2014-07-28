package models

import (
	"errors"
	"fmt"
	// "log"
	// "bytes"
	"os/exec"
	// "strconv"
	// "time"
)

var (
	Cmds map[string]*Cmd
)

// command: this.lineBuffer,
// dir: this.env.dir,
// user: this.env.userid,
// pass: this.env.password
type Cmd struct {
	Command string
	Params  string
	// User    string
	// Pass    string
}

type Result struct {
	Command string
	Params  string
	Success bool
	Result  string
}

func init() {
	Cmds = make(map[string]*Cmd)
	Cmds["dir"] = &Cmd{"dir", ""}
	Cmds["ping"] = &Cmd{"ping", "someone"}
}

func Run(Command string, Params string) (res *Result, err error) {

	// // cmd := exec.Command("cmd.exe ", Name)
	// cmd := exec.Command(Name, Params)
	// res = new(Result)
	// res.Name = Name
	// res.Params = Params

	// // var out bytes.Buffer
	// // cmd.Stdout = &out
	// // cmd.Stderr = &out

	// fmt.Println("Run begin...")
	// if err := cmd.Run(); err != nil {
	// 	fmt.Println("Run() error.")
	// 	res.Success = false
	// 	p, e := cmd.Output()
	// 	res.Info = string(p) + "Error: " + e.Error()
	// } else {
	// 	res.Success = true
	// 	p, e := cmd.Output()
	// 	res.Info = string(p) + "Error: " + e.Error()
	// }

	// fmt.Println("Run done!")

	res = new(Result)
	res.Command = Command
	res.Params = Params
	out, err := exec.Command(Command).Output()

	if err != nil {
		fmt.Printf(err.Error())
		res.Success = false
		res.Result = "Error: " + err.Error()
	} else {
		fmt.Printf("The date is :\n%s\n", out)
		res.Success = true
		res.Result = string(out)
	}

	return res, errors.New("no error")
}
