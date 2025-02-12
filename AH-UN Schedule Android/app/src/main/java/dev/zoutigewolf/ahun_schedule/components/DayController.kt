package dev.zoutigewolf.ahun_schedule.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.LocalContentColor
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import dev.zoutigewolf.ahun_schedule.DateUtils
import dev.zoutigewolf.ahun_schedule.api.AuthManager
import dev.zoutigewolf.ahun_schedule.api.models.Shift
import dev.zoutigewolf.ahun_schedule.toString
import kotlinx.datetime.LocalDate

@Composable
fun DayController(date: LocalDate, onDateChange: (LocalDate) -> Unit, schedule: List<Shift>, modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 6.dp)
                .padding(vertical = 6.dp),
            horizontalArrangement = Arrangement.Start,
            verticalAlignment = Alignment.CenterVertically
        ) {
            for (d in DateUtils.getDaysInWeek(date)) {
                DayIndicator(
                    date = d,
                    selected = d == date,
                    onClick = {
                        onDateChange(d)
                    },
                    shift = schedule
                        .filter { it.username == AuthManager.shared().user.value?.username }
                        .find { it.start.date == d },
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxWidth()
                )
            }
        }
    }
}

@Composable
fun DayIndicator(date: LocalDate, selected: Boolean, onClick: () -> Unit, shift: Shift? = null, modifier: Modifier = Modifier) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Top,
        modifier = modifier
    ) {
        TextButton(
            onClick = onClick,
            colors = ButtonDefaults.textButtonColors(
                contentColor = LocalContentColor.current
            ),
            contentPadding = PaddingValues(horizontal = 0.dp, vertical = 4.dp),
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = shift?.start?.toString("H:mm") ?: "",
                    style = TextStyle(textDecoration = if (shift?.canceled != true) TextDecoration.None else TextDecoration.LineThrough),
                    color = if (shift?.canceled != true) LocalContentColor.current else Color.Gray,
                )

                Text(
                    text = date.toString("E"),
                    color = MaterialTheme.colorScheme.onSecondaryContainer,
                )

                Text(
                    text = date.toString("d"),
                    color = if (date == DateUtils.now()) Color.Red else LocalContentColor.current
                )

                Box(modifier = Modifier
                    .padding(top = 6.dp)
                    .width(20.dp)
                    .height(2.dp)
                    .background(if (selected) Color.Gray else Color.Transparent)
                    .clip(RoundedCornerShape(8.dp)))
            }
        }
    }
}