{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# HLINT ignore "Use lambda-case" #-}

module Expr.Infix (parse) where

import Expr.Lexer
import Expr.AST
import Expr.Combinators
import Control.Applicative ((<|>))

-- Expr :: Expr - Expr | Expr + Expr (Левоассоциативно)
--       | Expr * Expr | Expr / Expr (Левоассоциативно)
--       | Expr ^ Expr               (Правоассоциативно)
--       | Digit
--       | ( Expr )
-- Expr :: Слаг + Слаг + ... + Слаг
-- Слаг :: Множ (* Множ) * ... (* Множ) -> [Expr]
-- Множ :: Цифра | Выражение в скобках
parse :: String -> Maybe (String, Expr)
parse = runParser (spaces *> parseExpr)

parseExpr :: Parser Expr
parseExpr = parseSum

parseSum :: Parser Expr
parseSum = leftAssoc toBinOp <$> list parseMult (plus <|> minus)

parseMult :: Parser Expr
parseMult = leftAssoc toBinOp <$> list parsePow (star <|> division)

parsePow :: Parser Expr
parsePow = rightAssoc toBinOp <$> list (number <|> ident <|> exprBr) hat

toBinOp :: Expr -> Op -> Expr -> Expr
toBinOp l op r = BinOp op l r

exprBr :: Parser Expr
exprBr = lbr *> parseSum <* rbr
