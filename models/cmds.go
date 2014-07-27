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

type Result struct {
	// Cmd
	Name    string
	Params  string
	Success bool
	Info    string
}

type Cmd struct {
	Name   string
	Params string
}

func init() {
	Cmds = make(map[string]*Cmd)
	Cmds["dir"] = &Cmd{"dir", ""}
	Cmds["ping"] = &Cmd{"ping", "someone"}
}

func Run(Name string, Params string) (res *Result, err error) {

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
	res.Name = Name
	res.Params = Params
	out, err := exec.Command(Name).Output()

	if err != nil {
		fmt.Printf(err.Error())
		res.Success = false
		res.Info = "Error: " + err.Error()
	} else {
		fmt.Printf("The date is :\n%s\n", out)
		res.Success = true
		res.Info = string(out)
	}

	return res, errors.New("no error")
}
