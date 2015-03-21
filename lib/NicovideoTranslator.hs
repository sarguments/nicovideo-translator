{-# LANGUAGE OverloadedStrings #-}
module NicovideoTranslator (translate) where

import Control.Lens ((^?))
import Data.Aeson.Lens (key)
import Data.Aeson.Types (Value(String))
import Data.ByteString.Lazy.Internal (ByteString)
import Data.LanguageCodes (ISO639_1, language)
import Data.Text (Text, pack)
import Network.Wreq (Response, FormParam((:=)), post, responseBody)

translate :: ISO639_1 -> Text -> IO Text
translate lang text =
    let response =
            post
            "http://translate.naver.com/translate.dic"
            [
                "query" := text,
                "srcLang" := ("ja" :: Text),
                "tarLang" := (pack $ language lang),
                "highlight" := ("0" :: Text),
                "hurigana" := ("0" :: Text)
            ]
        getResultData response = response ^? responseBody . key "resultData"
        resultData = response >>= return . getResultData
    in
        resultData >>= \dat -> case dat of
            Just (String translated) -> return translated
            _ -> ioError $ userError "translate.naver.com sent invalid response"
