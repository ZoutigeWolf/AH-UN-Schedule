package dev.zoutigewolf.ahun_schedule.components

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.LocalContentColor
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import dev.zoutigewolf.ahun_schedule.api.models.Shift
import dev.zoutigewolf.ahun_schedule.setTime
import dev.zoutigewolf.ahun_schedule.toString

@Composable
fun ShiftEditor(shift: Shift) {
    var isEditingStart: Boolean by remember { mutableStateOf(false) }
    var isEditingEnd: Boolean by remember { mutableStateOf(false) }

    var ended: Boolean by remember { mutableStateOf(shift.end != null) }
    var canceled: Boolean by remember { mutableStateOf(shift.canceled) }

    Column(
        modifier = Modifier
            .fillMaxHeight()
            .padding(horizontal = 16.dp),
    ) {
        Column(
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(
                text = shift.user.name,
                fontSize = 28.sp,
                modifier = Modifier
                    .padding(bottom = 24.dp)
            )

            Column(
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Start"
                    )

                    Text(
                        text = shift.start.toString("H:mm"),
                        modifier = Modifier
                            .clickable {
                                if (shift.canceled) return@clickable

                                isEditingStart = true
                            },
                        fontSize = 24.sp,
                        color = if (shift.canceled) Color.Gray else LocalContentColor.current
                    )
                }

                Row(
                    modifier = Modifier
                        .fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Text(
                        text = "End",
                        modifier = Modifier
                    )

                    Row(
                        horizontalArrangement = Arrangement.spacedBy(16.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Switch(
                            checked = ended,
                            onCheckedChange = {
                                ended = it
                                shift.end = if (it) shift.start.setTime(22, 0) else null
                            }
                        )

                        Text(
                            text = (shift.end ?: shift.start.setTime(22, 0)).toString("H:mm"),
                            modifier = Modifier
                                .clickable {
                                    if (shift.canceled || !ended) return@clickable

                                    isEditingEnd = true
                                },
                            fontSize = 24.sp,
                            color = if (shift.canceled || !ended) Color.Gray else LocalContentColor.current
                        )
                    }
                }

                Row(
                    modifier = Modifier
                        .fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Text(
                        text = "Canceled",
                        modifier = Modifier
                    )

                    Switch(checked = canceled, onCheckedChange = {
                        canceled = it
                        shift.canceled = it
                    })
                }
            }
        }
    }

    if (isEditingStart) {
        TimePickerDialog(
            time = shift.start,
            onDismiss = {
                isEditingStart = false
            },
            onConfirm = {
                isEditingStart = false
                shift.start = it
            }
        )
    }

    if (isEditingEnd) {
        TimePickerDialog(
            time=shift.end ?: shift.start.setTime(22, 0),
            onDismiss = {
                isEditingEnd = false
            },
            onConfirm = {
                isEditingEnd = false
                shift.end = it
            }
        )
    }
}