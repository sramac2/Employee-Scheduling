package main

import (
	"bufio"
	"fmt"
	"math/rand"
	"os"
	"strconv"
	"strings"
)

type Employee struct {
	ID          int
	Name        string
	Preferences map[string]int
}

var employees = make(map[int]Employee)
var schedule [7][3][]int
var employeeWorkingDays = make(map[int]int)

func main() {
	readCsvPreferences()
	computeSchedule()
	printSchedule()
}

func readCsvPreferences() {
	file, err := os.Open("preference.txt")
	if err != nil {
		fmt.Println("Error opening file:", err)
		return
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	idCounter := 1
	for scanner.Scan() {
		row := strings.TrimSpace(scanner.Text())
		fields := strings.Split(row, ",")
		if len(fields) != 8 {
			fmt.Println("Invalid row format")
			continue
		}
		preferences := make(map[string]int)
		days := []string{"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"}
		for i, day := range days {
			val, _ := strconv.Atoi(fields[i+1])
			preferences[day] = val
		}
		employees[idCounter] = Employee{ID: idCounter, Name: fields[0], Preferences: preferences}
		employeeWorkingDays[idCounter] = 0
		idCounter++
	}
}

func computeSchedule() {
	// Assign employees based on preference
	for dayIndex, day := range []string{"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"} {
		for _, e := range employees {
			preference := e.Preferences[day]
			if preference >= 0 && preference <= 2 && len(schedule[dayIndex][preference]) < 2 {
				addWorkingDay(dayIndex, preference, e.ID)
			}
		}
	}
	// Fill remaining slots randomly
	for dayIndex := 0; dayIndex < 7; dayIndex++ {
		addRandomEmployee(dayIndex, 0)
		addRandomEmployee(dayIndex, 1)
		addRandomEmployee(dayIndex, 2)
	}
}

func addRandomEmployee(dayIndex, shift int) {
	workers := schedule[dayIndex][shift]
	for len(workers) < 2 {
		empIDs := make([]int, 0, len(employeeWorkingDays))
		for id := range employeeWorkingDays {
			empIDs = append(empIDs, id)
		}
		if len(empIDs) == 0 {
			break
		}
		randomIdx := rand.Intn(len(empIDs))
		addWorkingDay(dayIndex, shift, empIDs[randomIdx])
		workers = schedule[dayIndex][shift]
	}
}

func addWorkingDay(dayIndex, shift, empID int) {
	schedule[dayIndex][shift] = append(schedule[dayIndex][shift], empID)
	employeeWorkingDays[empID]++
	if employeeWorkingDays[empID] >= 5 {
		delete(employeeWorkingDays, empID)
	}
}

func printSchedule() {
	fmt.Println("--------------------------------------------------------------")
	fmt.Println("| Day       | Morning            | Afternoon         | Evening           |")
	fmt.Println("--------------------------------------------------------------")
	days := []string{"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"}
	for dayIndex, day := range days {
		row := fmt.Sprintf("| %-10s", day)
		for shift := 0; shift < 3; shift++ {
			var empNames []string
			for _, id := range schedule[dayIndex][shift] {
				empNames = append(empNames, employees[id].Name)
			}
			row += fmt.Sprintf("| %-18s", strings.Join(empNames, ", "))
		}
		fmt.Println(row + "|")
		fmt.Println("--------------------------------------------------------------")
	}
}
