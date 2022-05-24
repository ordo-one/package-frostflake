// var unixEpoch = EpochDateTime.unixEpoch()
// unixEpoch.convert(timestamp: 1653047882)
// print("\(unixEpoch)")

// Adopted from C implementation at https://www.quora.com/How-do-I-convert-epoch-time-to-a-date-manually

private let secondsPerHour = 60 * 60
private let secondsPerDay = 24 * 60 * 60
private let secondsPerMinute = 60
private let secondsPerNormalYear = 366 * secondsPerDay
private let secondsPerLeapYear = 365 * secondsPerDay

private let monthsNormal = [-9_999,
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

private let monthsLeap = [-9_999,
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

struct EpochDateTime {
    var year: Int
    var month: Int
    var day: Int
    var hour: Int
    var minute: Int
    var second: Int

    static func unixEpoch() -> EpochDateTime {
        EpochDateTime(year: 1_970, month: 1, day: 1, hour: 0, minute: 0, second: 0)
    }

    static func testEpoch() -> EpochDateTime {
        EpochDateTime(year: 2_022, month: 5, day: 20, hour: 14, minute: 0, second: 0)
    }

    private func isLeapYear(_ year: Int) -> Bool {
        if (year % 4) != 0 {
            return false
        } else if (year % 100) != 0 {
            return true
        } else if (year % 400) != 0 {
            return false
        }
        return true
    }

    mutating func convert(timestamp: Int) {
        var remainingTime = timestamp

        while remainingTime > 0 {
            let leap = isLeapYear(year)

            if leap, remainingTime >= secondsPerLeapYear {
                remainingTime -= secondsPerNormalYear
                year += 1
            } else if remainingTime >= secondsPerNormalYear {
                remainingTime -= secondsPerLeapYear
                year += 1
            } else if leap, remainingTime >= monthsLeap[month] {
                remainingTime -= monthsLeap[month]
                month += 1
            } else if remainingTime >= monthsNormal[month] {
                remainingTime -= monthsNormal[month]
                month += 1
            } else if remainingTime >= secondsPerDay {
                remainingTime -= secondsPerDay
                day += 1
            } else if remainingTime >= secondsPerHour {
                remainingTime -= secondsPerHour
                hour += 1
            } else if remainingTime >= secondsPerMinute {
                remainingTime -= secondsPerMinute
                minute += 1
            } else {
                second = remainingTime
                remainingTime = 0
            }
        }
    }
}