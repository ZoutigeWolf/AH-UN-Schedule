package dev.zoutigewolf.ahun_schedule.screens

import androidx.compose.foundation.clickable
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.DateRange
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.ListItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavController

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(navController: NavController) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Settings") },
            )
        }
    ) { innerPadding ->
        LazyColumn(
            contentPadding = innerPadding
        ) {
            item {
                ListItem(
                    headlineContent = { Text("Account") },
                    leadingContent = { Icon(Icons.Default.Person, null) },
                    modifier = Modifier
                        .clickable {
                            navController.navigate("settings/account")
                        }
                )

                HorizontalDivider()
            }

            item {
                ListItem(
                    headlineContent = { Text("Calendar") },
                    leadingContent = { Icon(Icons.Default.DateRange, null) },
                    modifier = Modifier
                        .clickable {
                            navController.navigate("settings/calendar")
                        }
                )

                HorizontalDivider()
            }

            item {
                ListItem(
                    headlineContent = { Text("Notifications") },
                    leadingContent = { Icon(Icons.Default.Notifications, null) },
                    modifier = Modifier
                        .clickable {
                            navController.navigate("settings/notifications")
                        }
                )
            }
        }
    }
}