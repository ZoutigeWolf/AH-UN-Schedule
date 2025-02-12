package dev.zoutigewolf.ahun_schedule.api

import androidx.compose.runtime.Composable
import dev.zoutigewolf.ahun_schedule.api.models.Shift
import dev.zoutigewolf.ahun_schedule.api.models.ShiftUpdate
import dev.zoutigewolf.ahun_schedule.api.models.toUpdate
import dev.zoutigewolf.ahun_schedule.toString
import kotlinx.datetime.LocalDate

class ScheduleManager {
    companion object {
        private var instance: ScheduleManager? = null

        fun shared(): ScheduleManager {
            if (instance == null) {
                instance = ScheduleManager()
            }

            return instance!!
        }
    }

    fun getWeekSchedule(date: LocalDate, onCompletion: (List<Shift>) -> Unit) {
        Requests.get<List<Shift>>("/schedule/week/${date.toString("y")}/${date.toString("w")}") { success, data ->
            if (!success || data == null) {
                onCompletion(emptyList())
                return@get
            }

            onCompletion(data)
        }
    }

    fun updateShift(shift: Shift, onCompletion: (Shift?) -> Unit) {
        Requests.patch<ShiftUpdate, Shift>("/schedule/shift/${shift.id}", shift.toUpdate()) { success, data ->
            if (!success || data == null) {
                onCompletion(null)
                return@patch
            }

            onCompletion(data)
        }
    }
}