package dev.zoutigewolf.ahun_schedule.screens

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import dev.zoutigewolf.ahun_schedule.DateUtils
import dev.zoutigewolf.ahun_schedule.api.ScheduleManager
import dev.zoutigewolf.ahun_schedule.api.models.Shift
import dev.zoutigewolf.ahun_schedule.components.DayController
import dev.zoutigewolf.ahun_schedule.components.ScheduleList
import dev.zoutigewolf.ahun_schedule.components.WeekController
import dev.zoutigewolf.ahun_schedule.toString
import kotlinx.datetime.LocalDate

@Composable
fun ScheduleScreen() {
    var date: LocalDate by remember { mutableStateOf(DateUtils.now()) }
    var isLoading: Boolean by remember { mutableStateOf(false) }
    var schedule: List<Shift> by remember { mutableStateOf(mutableListOf()) }

    LaunchedEffect(date.toString("w")) {
        isLoading = true
        ScheduleManager.shared().getWeekSchedule(date) {
            schedule = it
            isLoading = false
        }
    }

    Column(modifier = Modifier.padding(top = 24.dp)) {
        WeekController(
            date = date,
            onDateChange = {
                isLoading = true
                date = it
            }
        )

        DayController(
            date = date,
            onDateChange = { date = it },
            schedule = schedule
        )

        ScheduleList(
            schedule = schedule.filter { it.start.date == date },
            isLoading = isLoading
        )
    }
}