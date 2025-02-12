package dev.zoutigewolf.ahun_schedule.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.LocalContentColor
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import dev.zoutigewolf.ahun_schedule.api.AuthManager
import dev.zoutigewolf.ahun_schedule.api.ScheduleManager
import dev.zoutigewolf.ahun_schedule.api.models.Shift
import dev.zoutigewolf.ahun_schedule.toString

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ScheduleList(schedule: List<Shift>, isLoading: Boolean = false) {
    var selectedShift: Shift? by remember { mutableStateOf(null) }
    var showEditModal: Boolean by remember { mutableStateOf(false) }

    if (isLoading || schedule.isEmpty()) {
        Column(
            modifier = Modifier
                .fillMaxSize(),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            if (isLoading) {
                CircularProgressIndicator()
            } else if (schedule.isEmpty()) {
                Text("No schedule for this week yet.")
                Button(onClick = {}) {
                    Text("Add Schedule")
                }
            }
        }

        return
    }

    Column(
        modifier = Modifier
            .padding(horizontal = 12.dp)
    ) {
        for ((time, shifts) in schedule.groupBy { it.start }.toSortedMap()) {
            Column(
                modifier = Modifier
                    .padding(top = 12.dp)
                    .verticalScroll(rememberScrollState())
            ) {
                Text(
                    time.toString("H:mm"),
                    modifier = Modifier
                        .padding(bottom = 2.dp)
                        .padding(horizontal = 6.dp)
                )

                for (s in shifts.sortedBy { it.user.name }) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(48.dp)
                            .padding(vertical = 4.dp)
                            .clip(RoundedCornerShape(8.dp))
                            .background(MaterialTheme.colorScheme.inverseOnSurface)
                            .clickable {
                                if (s.username != AuthManager.shared().user.value?.username
                                    && AuthManager.shared().user.value?.isAdmin != true) {
                                    return@clickable
                                }

                                selectedShift = s
                                showEditModal = true
                            },
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(
                            s.user.name,
                            style = TextStyle(textDecoration = if (!s.canceled) TextDecoration.None else TextDecoration.LineThrough),
                            fontWeight = if (s.username == AuthManager.shared().user.collectAsState().value?.username) FontWeight.Bold else FontWeight.Normal,
                            color = if (!s.canceled) LocalContentColor.current else Color.Gray,
                            modifier = Modifier
                                .padding(horizontal = 12.dp)
                        )
                        Text(
                            text = s.end?.toString("H:mm") ?: "",
                            modifier = Modifier
                                .padding(horizontal = 12.dp)
                        )
                    }
                }
            }
        }
    }

    if (showEditModal) {
        ModalBottomSheet(
            onDismissRequest = {
                showEditModal = false

                ScheduleManager.shared().updateShift(selectedShift!!) { }

                selectedShift = null
            },
            modifier = Modifier
                .fillMaxSize()
        ) {
            ShiftEditor(shift = selectedShift!!)
        }
    }
}