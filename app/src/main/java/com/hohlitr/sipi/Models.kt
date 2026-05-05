package com.hohlitr.sipi

import org.json.JSONArray
import org.json.JSONObject

data class StudyCollection(
    val id: String,
    val title: String,
    val description: String,
    val createdAt: String,
    val updatedAt: String
) {
    fun toJson(): JSONObject = JSONObject()
        .put("id", id)
        .put("title", title)
        .put("description", description)
        .put("createdAt", createdAt)
        .put("updatedAt", updatedAt)

    companion object {
        fun fromJson(json: JSONObject) = StudyCollection(
            id = json.getString("id"),
            title = json.getString("title"),
            description = json.optString("description"),
            createdAt = json.optString("createdAt"),
            updatedAt = json.optString("updatedAt"),
        )
    }
}

data class CardItem(
    val id: String,
    val collectionId: String,
    val question: String,
    val answer: String,
    val note: String,
    val wrongAnswers: List<String> = emptyList(),
    val mistakeCount: Int = 0,
    val correctAnswers: Int = 0,
    val attempts: Int = 0,
    val mastery: Double = 0.0
) {
    fun toJson(): JSONObject = JSONObject()
        .put("id", id)
        .put("collectionId", collectionId)
        .put("question", question)
        .put("answer", answer)
        .put("note", note)
        .put("wrongAnswers", JSONArray(wrongAnswers))
        .put("mistakeCount", mistakeCount)
        .put("correctAnswers", correctAnswers)
        .put("attempts", attempts)
        .put("mastery", mastery)

    companion object {
        fun fromJson(json: JSONObject) = CardItem(
            id = json.getString("id"),
            collectionId = json.getString("collectionId"),
            question = json.getString("question"),
            answer = json.getString("answer"),
            note = json.optString("note"),
            wrongAnswers = json.optJSONArray("wrongAnswers")?.toStringList().orEmpty(),
            mistakeCount = json.optInt("mistakeCount"),
            correctAnswers = json.optInt("correctAnswers"),
            attempts = json.optInt("attempts"),
            mastery = json.optDouble("mastery"),
        )
    }
}

data class CardGroup(
    val id: String,
    val collectionId: String,
    val title: String,
    val cardIds: List<String>
) {
    fun toJson(): JSONObject = JSONObject()
        .put("id", id)
        .put("collectionId", collectionId)
        .put("title", title)
        .put("cardIds", JSONArray(cardIds))

    companion object {
        fun fromJson(json: JSONObject) = CardGroup(
            id = json.getString("id"),
            collectionId = json.getString("collectionId"),
            title = json.getString("title"),
            cardIds = json.getJSONArray("cardIds").toStringList(),
        )
    }
}

data class StudyPlan(
    val id: String,
    val collectionId: String,
    val startDate: String,
    val endDate: String,
    val targetProgress: Double
) {
    fun toJson(): JSONObject = JSONObject()
        .put("id", id)
        .put("collectionId", collectionId)
        .put("startDate", startDate)
        .put("endDate", endDate)
        .put("targetProgress", targetProgress)

    companion object {
        fun fromJson(json: JSONObject) = StudyPlan(
            id = json.getString("id"),
            collectionId = json.getString("collectionId"),
            startDate = json.optString("startDate"),
            endDate = json.optString("endDate"),
            targetProgress = json.optDouble("targetProgress"),
        )
    }
}

data class Achievement(
    val title: String,
    val description: String,
    val requiredProgress: Double
)

val defaultAchievements = listOf(
    Achievement("Первый шаг", "создана первая коллекция", 0.0),
    Achievement("Уверенный прогресс", "изучено не меньше 50% темы", 0.5),
    Achievement("Мастер темы", "изучено не меньше 90% темы", 0.9),
)

fun JSONArray.forEachObject(block: (JSONObject) -> Unit) {
    for (i in 0 until length()) block(getJSONObject(i))
}

fun JSONArray.toStringList(): List<String> {
    val result = mutableListOf<String>()
    for (i in 0 until length()) result.add(getString(i))
    return result
}
