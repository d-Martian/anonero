/*
 * Copyright (c) 2018 m2049r
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.m2049r.xmrwallet.data

import android.util.Log
import com.m2049r.levin.scanner.LevinPeer
import com.m2049r.levin.util.NodePinger
import com.m2049r.xmrwallet.model.WalletManager
import lombok.Getter
import lombok.Setter
import lombok.ToString
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONException
import org.json.JSONObject
import timber.log.Timber
import xmr.anon_wallet.wallet.AnonWallet
import xmr.anon_wallet.wallet.utils.AnonPreferences
import java.io.IOException
import java.net.HttpURLConnection
import java.net.InetSocketAddress
import java.net.Proxy
import java.net.SocketAddress

class NodeInfo : Node {
    private var height: Long = 0

    private var timestamp: Long = 0

    private var majorVersion = 0

    private var responseTime = Double.MAX_VALUE

    private var responseCode = 0

    private var tested = false


    @Setter
    private val selecting = false
    fun clear() {
        height = 0
        majorVersion = 0
        responseTime = Double.MAX_VALUE
        responseCode = 0
        timestamp = 0
        tested = false
    }

    constructor(anotherNode: NodeInfo) : super(anotherNode) {
        overwriteWith(anotherNode)
    }

    // use default peer port if not set - very few peers use nonstandard port
    @get:Synchronized
    var levinSocketAddress: SocketAddress? = null
        get() {
            if (field == null) {
                // use default peer port if not set - very few peers use nonstandard port
                field = InetSocketAddress(hostAddress.hostAddress, getDefaultLevinPort())
            }
            return field
        }
        private set

    override fun hashCode(): Int {
        return super.hashCode()
    }

    override fun equals(other: Any?): Boolean {
        return super.equals(other)
    }

    fun toHashMap(): HashMap<String, Any> {
        val hashMap = hashMapOf<String, Any>()
        hashMap["height"] = height
        hashMap["blockchainHeight"] = WalletManager.getInstance().blockchainHeight ?: 0
        hashMap["responseCode"] = responseCode
        hashMap["host"] = host
        hashMap["rpcPort"] = rpcPort
        hashMap["majorVersion"] = majorVersion
        hashMap["levinPort"] = levinPort
        hashMap["username"] = username ?: ""
        hashMap["password"] = password ?: ""
        hashMap["EVENT_TYPE"] = "NODE"
        hashMap["favourite"] = this.isFavourite
        hashMap["isActive"] =  false
        return hashMap
    }

    constructor(nodeString: String?) : super(nodeString) {}
    constructor(levinPeer: LevinPeer) : super(levinPeer.getSocketAddress()) {}
    constructor(address: InetSocketAddress?) : super(address) {}
    constructor() : super() {}

    val isSuccessful: Boolean
        get() = responseCode in 200..299
    val isUnauthorized: Boolean
        get() = responseCode == HttpURLConnection.HTTP_UNAUTHORIZED
    val isValid: Boolean
        get() = isSuccessful && majorVersion >= MIN_MAJOR_VERSION && responseTime < Double.MAX_VALUE

    fun overwriteWith(anotherNode: NodeInfo) {
        super.overwriteWith(anotherNode)
        height = anotherNode.height
        timestamp = anotherNode.timestamp
        majorVersion = anotherNode.majorVersion
        responseTime = anotherNode.responseTime
        responseCode = anotherNode.responseCode
    }

    override fun toNodeString(): String {
        return super.toString()
    }

    override fun toString(): String {
        val sb = StringBuilder()
        sb.append(super.toString())
        sb.append("?rc=").append(responseCode)
        sb.append("?v=").append(majorVersion)
        sb.append("&h=").append(height)
        sb.append("&ts=").append(timestamp)
        if (responseTime < Double.MAX_VALUE) {
            sb.append("&t=").append(responseTime).append("ms")
        }
        return sb.toString()
    }

    fun testRpcService(): Boolean? {
        return testRpcService(rpcPort)
    }

    fun testRpcService(listener: NodePinger.Listener?): Boolean? {
        val result = testRpcService(rpcPort)
        listener?.publish(this)
        return result
    }

    private fun rpcServiceRequest(port: Int): Request {
        val url: HttpUrl = HttpUrl.Builder().scheme("http").host(this.host).port(port).addPathSegment("json_rpc").build()
        val json = "{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"getlastblockheader\"}"
        return Request(url, json, this.username, password)
    }

    fun getHeight(): Long {
        return height
    }

    private fun testRpcService(port: Int): Boolean? {
        Timber.d("Testing %s", toNodeString())
        clear()
        //TODO: TOR REFACTOR
        /*
        if (hostAddress.isOnion() && !NetCipherHelper.isTor()) {
         */
//        if (hostAddress.isOnion) {
//            tested = true // sortof
//            responseCode = 418 // I'm a teapot - or I need an Onion - who knows
//            return false // autofail
//        }
        try {
            val ta = System.nanoTime()

            rpcServiceRequest(port).execute().use { response ->
                Timber.d("%s: %s", response.code, response.request.url)
                responseTime = (System.nanoTime() - ta) / 1000000.0
                responseCode = response.code
                if (response.isSuccessful) {
                    val respBody = response.body // closed through Response object
                    if (respBody != null && respBody.contentLength() < 2000) { // sanity check
                        val json = JSONObject(respBody.string())
                        val rpcVersion = json.getString("jsonrpc")
                        if (RPC_VERSION != rpcVersion) return false
                        val result = json.getJSONObject("result")
                        if (!result.has("credits")) // introduced in monero v0.15.0
                            return false
                        val header = result.getJSONObject("block_header")
                        height = header.getLong("height")
                        timestamp = header.getLong("timestamp")
                        majorVersion = header.getInt("major_version")
                        return true // success
                    }
                }
            }
        } catch (ex: IOException) {
            ex.printStackTrace()
            throw  ex;
            Timber.d("EX: %s", ex.message) //TODO: do something here (show error?)
        } catch (ex: JSONException) {
            ex.printStackTrace()
            throw  ex;
            Timber.d("EX: %s", ex.message)
        } finally {
            tested = true
        }
        return false
    }

    fun findRpcService(): Boolean? {
        // if already have an rpcPort, use that
        if (rpcPort > 0) return testRpcService(rpcPort)
        // otherwise try to find one
        for (port in TEST_PORTS) {
            if (testRpcService(port) == true) { // found a service
                rpcPort = port
                return true
            }
        }
        return false
    }
    //
    //    public void showInfo(@NonNull TextView view, String info, boolean isError) {
    //        final Context ctx = view.getContext();
    //        final Spanned text = Html.fromHtml(ctx.getString(R.string.status,
    //                Integer.toHexString(ThemeHelper.getThemedColor(ctx, R.attr.positiveColor) & 0xFFFFFF),
    //                Integer.toHexString(ThemeHelper.getThemedColor(ctx, android.R.attr.colorBackground) & 0xFFFFFF),
    //                (hostAddress.isOnion() ? "&nbsp;.onion&nbsp;&nbsp;" : ""), " " + info));
    //        view.setText(text);
    //        if (isError)
    //            view.setTextColor(ThemeHelper.getThemedColor(ctx, R.attr.colorError));
    //        else
    //            view.setTextColor(ThemeHelper.getThemedColor(ctx, android.R.attr.textColorSecondary));
    //    }
    //
    //    public void showInfo(TextView view) {
    //        if (!isTested()) {
    //            showInfo(view, "", false);
    //            return;
    //        }
    //        final Context ctx = view.getContext();
    //        final long now = Calendar.getInstance().getTimeInMillis() / 1000;
    //        final long secs = (now - timestamp);
    //        final long mins = secs / 60;
    //        final long hours = mins / 60;
    //        final long days = hours / 24;
    //        String info;
    //        if (mins < 2) {
    //            info = ctx.getString(R.string.node_updated_now, secs);
    //        } else if (hours < 2) {
    //            info = ctx.getString(R.string.node_updated_mins, mins);
    //        } else if (days < 2) {
    //            info = ctx.getString(R.string.node_updated_hours, hours);
    //        } else {
    //            info = ctx.getString(R.string.node_updated_days, days);
    //        }
    //        showInfo(view, info, hours >= STALE_NODE_HOURS);
    //    }


    @ToString
    class Request @JvmOverloads constructor(
        val url: HttpUrl?, val json: String? = null, val username: String? = null, val password: String? = null
    ) {
        constructor(url: HttpUrl?, json: JSONObject?) : this(url, json?.toString(), null, null) {}

        fun enqueue(callback: Callback?) {
            newCall().enqueue(callback!!)
        }

        @Throws(IOException::class)
        fun execute(): Response {
            return newCall().execute()
        }

        private fun newCall(): Call {
            return client!!.newCall(request)
        }

        // Unit-test mode
        private val client:
        //            if ((username != null) && (!username.isEmpty())) {
        //TODO: DO OKHTTP AUTH AND TOR PROXY
//                final DigestAuthenticator authenticator = new DigestAuthenticator(new Credentials(username, password));
//                final Map<String, CachingAuthenticator> authCache = new ConcurrentHashMap<>();
//                return client.newBuilder()
//                        .authenticator(new CachingAuthenticatorDecorator(authenticator, authCache))
//                        .addInterceptor(new AuthenticationCacheInterceptor(authCache))
//                        .build();
        // TODO: maybe cache & reuse the client for these credentials?
//            } else {
//                return client;
//            }
                OkHttpClient?
            private get() = if (mockClient != null) mockClient else OkHttpClient.Builder().apply {
                    val preferences = AnonPreferences(AnonWallet.getAppContext())
                    if (!preferences.proxyServer.isNullOrEmpty() && !preferences.proxyPort.isNullOrEmpty()) {
                        val iSock = InetSocketAddress(
                            preferences.proxyServer, preferences.proxyPort!!.trim().toInt()
                        )
                        this.proxy(Proxy(Proxy.Type.SOCKS, iSock))
                    }
                }.build() // Unit-test mode

        //            if ((username != null) && (!username.isEmpty())) {
        //TODO: DO OKHTTP AUTH AND TOR PROXY
//                final DigestAuthenticator authenticator = new DigestAuthenticator(new Credentials(username, password));
//                final Map<String, CachingAuthenticator> authCache = new ConcurrentHashMap<>();
//                return client.newBuilder()
//                        .authenticator(new CachingAuthenticatorDecorator(authenticator, authCache))
//                        .addInterceptor(new AuthenticationCacheInterceptor(authCache))
//                        .build();
        // TODO: maybe cache & reuse the client for these credentials?
//            } else {
//                return client;
//            }
        private val request: okhttp3.Request
            get() {
                val builder: okhttp3.Request.Builder = okhttp3.Request.Builder().url(url!!).header("User-Agent", USER_AGENT)
                if (json != null) {
                    builder.post(json.toRequestBody("application/json".toMediaTypeOrNull()))
                } else {
                    builder.get()
                }
                return builder.build()
            }

        companion object {
            // for unit tests only
            var mockClient: OkHttpClient? = null
        }
    }

    companion object {
        const val MIN_MAJOR_VERSION = 14
        const val RPC_VERSION = "2.0"
        const val USER_AGENT = "Monerujo/1.0"
        fun fromString(nodeString: String?): NodeInfo? {
            return try {
                NodeInfo(nodeString)
            } catch (ex: IllegalArgumentException) {
                null
            }
        }

        var BestNodeComparator = label@ java.util.Comparator { o1: NodeInfo, o2: NodeInfo ->
            if (o1.isValid) {
                if (o2.isValid) { // both are valid
                    // higher node wins
                    val heightDiff = (o2.height - o1.height).toInt()
                    if (heightDiff != 0) return@Comparator heightDiff
                    // if they are equal, faster node wins
                    return@Comparator Math.signum(o1.responseTime - o2.responseTime).toInt()
                } else {
                    return@Comparator -1
                }
            } else {
                return@Comparator 1
            }
        }
        private const val HTTP_TIMEOUT = 1000 //ms
        const val PING_GOOD = HTTP_TIMEOUT / 3.0 //ms
        const val PING_MEDIUM = 2 * PING_GOOD //ms
        const val PING_BAD = HTTP_TIMEOUT.toDouble()
        private val TEST_PORTS = intArrayOf(18089) // check only opt-in port
        const val STALE_NODE_HOURS = 2
    }
}