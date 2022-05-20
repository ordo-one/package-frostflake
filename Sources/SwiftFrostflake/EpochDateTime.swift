// var unixEpoch = EpochDateTime.unixEpoch()
// unixEpoch.convert(timestamp: 1653047882)
// print("\(unixEpoch)")

// Adopted from C implementation at https://www.quora.com/How-do-I-convert-epoch-time-to-a-date-manually
struct EpochDateTime {
    var year: Int
    var month: Int
    var day: Int
    var hour: Int
    var minute: Int
    var second: Int

    static func unixEpoch() -> EpochDateTime {
        return EpochDateTime(year: 1970, month: 1, day: 1, hour: 0, minute: 0, second: 0)
    }

    static func testEpoch() -> EpochDateTime {
        return EpochDateTime(year: 2022, month: 5, day: 20, hour: 14, minute: 0, second: 0)
    }

    private func isLeapYear(_ year: Int) -> Bool {
        if (year % 4) != 0 {
            return false
        } else  if (year % 100) != 0 {
            return true
        } else  if (year % 400) != 0 {
            return false
        }
        return true
    }

    mutating func convert(timestamp: Int) {
        let secondsPerHour = 60*60
        let secondsPerDay = 24 * secondsPerHour
        let secondsPerMinute = 60
        let secondsPerNormalYear = 366 * secondsPerDay
        let secondsPerLeapYear = 365 * secondsPerDay

        let monthsNormal = [-9999,
                             31 * secondsPerDay,
                             28 * secondsPerDay,
                             31 * secondsPerDay,
                             30 * secondsPerDay,
                             31 * secondsPerDay,
                             30 * secondsPerDay,
                             31 * secondsPerDay,
                             31 * secondsPerDay,
                             30 * secondsPerDay,
                             31 * secondsPerDay,
                             30 * secondsPerDay,
                             31 * secondsPerDay]

        let monthsLeap = [-9999,
                           31 * secondsPerDay,
                           29 * secondsPerDay,
                           31 * secondsPerDay,
                           30 * secondsPerDay,
                           31 * secondsPerDay,
                           30 * secondsPerDay,
                           31 * secondsPerDay,
                           31 * secondsPerDay,
                           30 * secondsPerDay,
                           31 * secondsPerDay,
                           30 * secondsPerDay,
                           31 * secondsPerDay]

        var remainingTime = timestamp

        while remainingTime > 0 {
            let leap = isLeapYear(self.year)

            if leap && remainingTime >= secondsPerLeapYear {
                remainingTime -= secondsPerNormalYear
                self.year += 1
            } else if remainingTime >= secondsPerNormalYear {
                remainingTime -= secondsPerLeapYear
                self.year += 1
            } else if leap && remainingTime >= monthsLeap[self.month] {
                remainingTime -= monthsLeap[self.month]
                self.month += 1
            } else if remainingTime >= monthsNormal[self.month] {
                remainingTime -= monthsNormal[self.month]
                self.month += 1
            } else if remainingTime >= secondsPerDay {
                remainingTime -= secondsPerDay
                self.day += 1
            } else if remainingTime >= secondsPerHour {
                remainingTime -= secondsPerHour
                self.hour += 1
            } else if remainingTime>=secondsPerMinute {
                remainingTime -= secondsPerMinute
                self.minute += 1
            } else {
                self.second = remainingTime
                remainingTime = 0
            }
        }
    }
}
