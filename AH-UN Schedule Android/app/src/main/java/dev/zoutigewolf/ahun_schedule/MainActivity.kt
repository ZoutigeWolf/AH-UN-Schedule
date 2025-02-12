package dev.zoutigewolf.ahun_schedule

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.annotation.StringRes
import androidx.compose.animation.EnterTransition
import androidx.compose.animation.ExitTransition
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.DateRange
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.navigation.NavController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import dev.zoutigewolf.ahun_schedule.api.AuthManager
import dev.zoutigewolf.ahun_schedule.screens.AccountSettingsScreen
import dev.zoutigewolf.ahun_schedule.screens.CalendarSettingsScreen
import dev.zoutigewolf.ahun_schedule.screens.InsightsScreen
import dev.zoutigewolf.ahun_schedule.screens.LoginScreen
import dev.zoutigewolf.ahun_schedule.screens.NotificationsSettingsScreen
import dev.zoutigewolf.ahun_schedule.screens.ScheduleScreen
import dev.zoutigewolf.ahun_schedule.screens.SettingsScreen
import dev.zoutigewolf.ahun_schedule.screens.UsersScreen
import dev.zoutigewolf.ahun_schedule.ui.theme.AHUNScheduleTheme

sealed class Screen(val route: String, @StringRes val resourceId: Int, val icon: ImageVector?) {
    data object Schedule : Screen("schedule", R.string.tab_schedule, Icons.Default.DateRange)
    data object Insights : Screen("insights", R.string.tab_insights, Icons.Default.Menu)
    data object Users : Screen("users", R.string.tab_users, Icons.Default.Person)
    data object Settings : Screen("settings", R.string.tab_settings, Icons.Default.Settings)
    data object AccountSettings : Screen("settings/account", R.string.tab_settings_account, null)
    data object CalendarSettings : Screen("settings/calendar", R.string.tab_settings_calendar, null)
    data object NotificationsSettings : Screen("settings/notifications", R.string.tab_settings_notifications, null)
}

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        tryAuthenticate()

        setContent {
            AHUNScheduleTheme {
                if (AuthManager.shared().token.collectAsState(initial = null).value != null) {
                    App()
                } else {
                    LoginScreen()
                }
            }
        }
    }

    private fun tryAuthenticate() {
        val credentialsManager = CredentialsManager(this)
        val credentials = credentialsManager.loadUserCredentials() ?: return

        AuthManager.shared().login(credentials) { success ->
            if (!success) {
                credentialsManager.deleteUserCredentials()
            }
        }
    }
}

@Composable
fun App() {
    val navController = rememberNavController()
    val items = mutableListOf(
        Screen.Schedule,
        Screen.Insights,
        Screen.Settings
    )

    if (AuthManager.shared().user.collectAsState().value?.isAdmin == true) {
        items.add(2, Screen.Users)
    }

    Scaffold(
        bottomBar = { AppNavigationBar(navController, items) }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = Screen.Schedule.route,
            enterTransition = {
                EnterTransition.None
            },
            exitTransition = {
                ExitTransition.None
            },
            modifier = Modifier
                .padding(innerPadding)
        ) {
            composable(Screen.Schedule.route) { ScheduleScreen() }
            composable(Screen.Insights.route) { InsightsScreen() }
            composable(Screen.Users.route) { UsersScreen() }
            composable(Screen.Settings.route) { SettingsScreen(navController) }
            composable(Screen.AccountSettings.route) { AccountSettingsScreen(navController) }
            composable(Screen.CalendarSettings.route) { CalendarSettingsScreen(navController) }
            composable(Screen.NotificationsSettings.route) { NotificationsSettingsScreen(navController) }
        }
    }
}

@Composable
fun AppNavigationBar(navController: NavController, items: List<Screen>) {
    NavigationBar {
        val currentBackStackEntry by navController.currentBackStackEntryAsState()

        items.forEach { screen ->
            val selected = currentBackStackEntry?.destination?.route?.startsWith(screen.route) ?: false

            NavigationBarItem(
                icon = { if (screen.icon != null) { Icon(screen.icon, contentDescription = null) } },
                label = { Text(stringResource(screen.resourceId)) },
                selected = selected,
                onClick = {
                    if (selected) {
                        return@NavigationBarItem
                    }

                    navController.navigate(screen.route) {
                        popUpTo(navController.graph.startDestinationId) {
                            saveState = true
                        }

                        launchSingleTop = true
                        restoreState = true
                    }
                }
            )
        }
    }
}