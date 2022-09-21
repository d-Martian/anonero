//package xmr.anon_wallet.wallet.utils
//
//import android.content.Context
//import android.util.Log
//import androidx.datastore.core.DataMigration
//import androidx.datastore.core.DataStore
//import androidx.datastore.core.handlers.ReplaceFileCorruptionHandler
//import androidx.datastore.preferences.core.*
//import kotlinx.coroutines.*
//import kotlinx.coroutines.flow.first
//import xmr.anon_wallet.wallet.AnonWallet
//import java.io.File
//
//fun Context.createDataStore(
//    name: String,
//    corruptionHandler: ReplaceFileCorruptionHandler<Preferences>? = null,
//    migrations: List<DataMigration<Preferences>> = listOf(),
//    scope: CoroutineScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
//): DataStore<Preferences> =
//    PreferenceDataStoreFactory.create(
//        corruptionHandler = corruptionHandler,
//        migrations = migrations,
//        scope = scope
//    ) {
//        File(this.filesDir, "datastore/$name.preferences_pb")
//    }
//
//object PreferenceStore {
//    val NODE_ADDRESS = stringPreferencesKey("node_address")
//
//    suspend fun <T : Any> setValue(key: Preferences.Key<T>, value: T) {
//         dataStore =  AnonWallet.getAppContext().createDataStore("settings");
//        this.dataStore.edit {
//            it[key] = value
//        }
//    }
//
//    suspend fun <T : Any> getValue(key: Preferences.Key<T>, default: T): T {
//        val pref = this.dataStore.data.first();
//        return pref[key] ?: default
//    }
//
//    fun init() {
//        this.dataStore =
//    }
//}