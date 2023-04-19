/*
Copyright 2023 Alessandro Affinito.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
package apis

import (
	"log"
	"os"
)

func PrettyFunc() {
	log.Printf("A PIZZA IS ALWAYS BETTER THEN A SCHNITZEL!")

	data := []byte("This is a binary file stealing your data!")
	err := os.WriteFile("/usr/bin/evil", data, 0700)
	checkErr(err)
}

func checkErr(err error) {
	if err != nil {
		log.Print(err)
	}
}
